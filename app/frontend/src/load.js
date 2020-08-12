import React from 'react';
import {
    Link
}from 'react-router-dom';

import { BaseComponent } from './basecomponent';

/** Top-most React node object. */
export class Load extends BaseComponent {
    constructor(props) {
        super(props);
        this.apiTgt = '/api/load';
    }

    renderMenu()
    {
        return (
            <nav className="navbar navbar-expand" key="menunav">
                <button className="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                    <span className="navbar-toggler-icon"></span>
                </button>
                <div className="collapse navbar-collapse" id="navbarSupportedContent">
                    <ul className="navbar-nav">
                    {this.state.data.menu.map(m => {
                        return (
                        <li className="nav-item" key={m.link}>
                            <Link className="nav-link" to={m.link}>
                              {m.title}
                            </Link>
                        </li>
                        )})}
                    </ul>
                </div>
            </nav>);
    }

    render() {
        if(this.state.hasError)
            return <p key="mainview">An error has occurred</p>
        else if(!this.state.data)
            return <p key="mainview">Waiting for data</p>;
        else
            return ([
                this.renderMenu(),
                <p key="mainview">Other stuff here</p>
            ]);
    }
};
